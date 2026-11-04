"""Marktstände nachts zu (D20d, VORLÄUFIG bis zu Marcos Bildern): Das Dach wird als Vorhang heruntergelassen.

Aus assets/baukasten/objekte/marktstand_rot.png und marktstand_blau.png entstehen *_zu.png: Unter dem Dach hängt ein
gestreifter Stoff in den Farben des Dachs bis über die Ware. Kommen Marcos gezeichnete Bilder, ersetzen sie diese.
Aufruf: python3 tools/marktstand_zu.py   (braucht numpy, scipy und Pillow)
"""
import math
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

OBJEKTE = Path(__file__).resolve().parent.parent / "assets" / "baukasten" / "objekte"
## Stand -> wie weit der Vorhang unter das Dach fällt (Pixel)
STAENDE = [("marktstand_rot", 46), ("marktstand_blau", 50)]
for n, fall in STAENDE:
	a = np.array(Image.open(OBJEKTE / f"{n}.png").convert("RGBA"))
	h,w=a.shape[:2]
	rgb=a[...,:3].astype(int); al=a[...,3]>128
	r,g,b=rgb[...,0],rgb[...,1],rgb[...,2]
	stoff=((r>140)&(r>g+40)&(r>b+40)) if 'rot' in n else ((b>120)&(b>r+30))
	hell=(r>200)&(g>190)&(b>170)
	oben=np.arange(h)[:,None]<h*0.55
	maske=ndimage.binary_closing(al&oben&(stoff|hell),iterations=2)&al
	lab,k=ndimage.label(maske); m=lab==(np.argmax(ndimage.sum(maske,lab,range(1,k+1)))+1)
	farbe=np.median(rgb[m&stoff],0); hellf=np.median(rgb[m&hell],0) if (m&hell).any() else farbe
	erg=a.copy()
	cols=np.where(m.any(0))[0]
	x0,x1=cols.min()+6,cols.max()-6
	for x in range(x0,x1+1):
		ys=np.where(m[:,x])[0]; y0=ys.max()
		y_end=min(h-1,y0+fall)
		# Streifen wie das Dach: abwechselnd Farbe und hell, Falten als Schatten
		streifen=int((x-x0)/18)%2==1
		basis=hellf if streifen else farbe
		falte=0.85+0.15*math.cos((x-x0)/6.0)
		for y in range(y0,y_end+1):
			tiefe=1.0-0.25*(y-y0)/fall
			c=np.clip(basis*falte*tiefe,0,255)
			erg[y,x,:3]=c; erg[y,x,3]=255
		# dunkler Saum unten
		erg[y_end,x,:3]=(40,28,20)
	Image.fromarray(erg).save(OBJEKTE / f"{n}_zu.png")
	print(f"{n}_zu.png")
