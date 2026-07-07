# ตัดพื้นหลังรูป (flood-fill จากขอบภาพแบบไล่ gradient) → PNG โปร่งใส ลง OutputDir
# ใช้กับภาพการ์ตูน/วัตถุที่พื้นหลังเป็นสีเรียบ (ขาว/อ่อน) — ไม่เหมาะกับภาพถ่ายวัตถุใส
# (แก้วน้ำ/น้ำแข็ง) หรือภาพฉากเต็มเฟรม (จะกัดทะลุ) → พวกนั้นใช้ภาพเต็มแทน
#
# วิธีใช้:  ./tool/cutout_images.ps1 -InputDir path\to\raw -OutputDir assets\images\vocab
#          (ตัด *.png/*.jpg/*.jpeg ทุกไฟล์ → <basename>.png, ย่อสูงสุด 512px)
# ไม่ต้องมี Python/ffmpeg — ใช้ System.Drawing ของ .NET ล้วน
param(
  [Parameter(Mandatory = $true)][string]$InputDir,
  [Parameter(Mandatory = $true)][string]$OutputDir,
  [int]$MaxSide = 512,
  [double]$BaseTol = 45.0,   # ระยะสีจากพื้นหลังอ้างอิงที่ถือว่า "พื้นหลัง"
  [double]$GradTol = 10.0,   # ระยะไล่เฉดที่ยอมให้ลามต่อ
  [double]$RefCap = 95.0,    # เพดานกันลามเข้าตัววัตถุ
  [double]$FringeTol = 60.0  # เก็บขอบฟุ้ง
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path $InputDir)) { Write-Error "ไม่พบ $InputDir"; exit 1 }
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Force $OutputDir | Out-Null }

$cs = @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class Cutout {
  static double Dist(byte[] p, int i, int j) {
    int db = p[i]-p[j], dg = p[i+1]-p[j+1], dr = p[i+2]-p[j+2];
    return Math.Sqrt(db*db + dg*dg + dr*dr);
  }
  static double DistRef(byte[] p, int i, double b, double g, double r) {
    double db = p[i]-b, dg = p[i+1]-g, dr = p[i+2]-r;
    return Math.Sqrt(db*db + dg*dg + dr*dr);
  }
  // คืน % ที่ลบ (string invariant — PS 5.1 binder ไม่รับ static double)
  public static string Process(string inPath, string outPath, int maxSide,
      double baseTol, double gradTol, double refCap, double fringeTol) {
    using (var src = new Bitmap(inPath)) {
      int w = src.Width, h = src.Height;
      var rect = new Rectangle(0, 0, w, h);
      using (var bmp = src.Clone(rect, PixelFormat.Format32bppArgb)) {
        var bd = bmp.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
        int stride = bd.Stride;
        var px = new byte[stride * h];
        Marshal.Copy(bd.Scan0, px, 0, px.Length);
        double rb=0, gg=0, rr=0; long n=0;
        Action<int,int> acc = (x,y) => { int i=y*stride+x*4; rb+=px[i]; gg+=px[i+1]; rr+=px[i+2]; };
        for (int x=0;x<w;x++){acc(x,0);acc(x,h-1);n+=2;}
        for (int y=1;y<h-1;y++){acc(0,y);acc(w-1,y);n+=2;}
        rb/=n; gg/=n; rr/=n;
        var bg = new bool[w*h];
        var q = new Queue<int>();
        Action<int,int> seed = (x,y) => {
          int idx=y*w+x; if (bg[idx]) return;
          if (DistRef(px, y*stride+x*4, rb, gg, rr) < baseTol) { bg[idx]=true; q.Enqueue(idx); }
        };
        for (int x=0;x<w;x++){seed(x,0);seed(x,h-1);}
        for (int y=0;y<h;y++){seed(0,y);seed(w-1,y);}
        int[] dx={1,-1,0,0}, dy={0,0,1,-1};
        while (q.Count>0){
          int cur=q.Dequeue(); int cx=cur%w, cy=cur/w, ci=cy*stride+cx*4;
          for (int d=0;d<4;d++){
            int nx=cx+dx[d], ny=cy+dy[d];
            if (nx<0||ny<0||nx>=w||ny>=h) continue;
            int nidx=ny*w+nx; if (bg[nidx]) continue;
            int ni=ny*stride+nx*4; double dRef=DistRef(px,ni,rb,gg,rr);
            if (dRef<baseTol || (Dist(px,ni,ci)<gradTol && dRef<refCap)) { bg[nidx]=true; q.Enqueue(nidx); }
          }
        }
        var fringe = new List<int>();
        for (int y=0;y<h;y++) for (int x=0;x<w;x++){
          int idx=y*w+x; if (bg[idx]) continue;
          bool t=(x>0&&bg[idx-1])||(x<w-1&&bg[idx+1])||(y>0&&bg[idx-w])||(y<h-1&&bg[idx+w]);
          if (t && DistRef(px,y*stride+x*4,rb,gg,rr)<fringeTol) fringe.Add(idx);
        }
        foreach (int idx in fringe) bg[idx]=true;
        long removed=0;
        for (int y=0;y<h;y++) for (int x=0;x<w;x++)
          if (bg[y*w+x]) { px[y*stride+x*4+3]=0; removed++; }
        Marshal.Copy(px, 0, bd.Scan0, px.Length);
        bmp.UnlockBits(bd);
        double ratio = Math.Min(1.0, (double)maxSide/Math.Max(w,h));
        int nw=(int)Math.Round(w*ratio), nh=(int)Math.Round(h*ratio);
        using (var outBmp = new Bitmap(nw, nh, PixelFormat.Format32bppArgb))
        using (var g2 = Graphics.FromImage(outBmp)) {
          g2.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceCopy;
          g2.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
          g2.DrawImage(bmp, new Rectangle(0,0,nw,nh));
          outBmp.Save(outPath, ImageFormat.Png);
        }
        return (removed*100.0/((long)w*h)).ToString("F1", System.Globalization.CultureInfo.InvariantCulture);
      }
    }
  }
}
'@
Add-Type -TypeDefinition $cs -ReferencedAssemblies System.Drawing

$files = @(Get-ChildItem $InputDir -Include *.png,*.jpg,*.jpeg -File -Recurse)
foreach ($f in $files) {
  $out = Join-Path $OutputDir ($f.BaseName + '.png')
  $pct = [Cutout]::Process($f.FullName, $out, $MaxSide, $BaseTol, $GradTol, $RefCap, $FringeTol)
  $warn = if ([double]::Parse($pct, [System.Globalization.CultureInfo]::InvariantCulture) -lt 40) { '  <-- ตัดได้น้อย เช็คว่าเหมาะกับ cutout ไหม' } else { '' }
  Write-Host ("{0} -> {1}.png (ลบ {2}%){3}" -f $f.Name, $f.BaseName, $pct, $warn)
}
Write-Host "เสร็จ $($files.Count) ไฟล์ -> $OutputDir"
