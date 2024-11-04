m4_include(common.html.m4)

WEB_PAGE([
SECTION([SSS],
[> Siz kimsiniz?
Turkiye bazli bir Linux kullanici grubuyuz. Matrix'te takilip <i>cool</i> yazilimlar hostluyoruz.

> Size katilabilir miyim?
Matrix'e bekleriz. Footer'da link mevcut.])

m4_ifelse(MOBILE, 1, [], [
SECTION([SSH Parmakizleri],
[vflower:
SHA256:3J9laeo21EdP5D70CO2Jxkrexivj3iWEATJYXle9Sik (RSA)
SHA256:YTE7aW9ADbrxv+h5fZB8afBYAkePMRdSXfXHbhR61PY (ED25519)])
])

SECTION([Sunucu Logu],
[2024-10-03 - @ikolomiko'ya 2 aylik sunucu masrafini karsiladigi icin tesekkur ederiz!
2024-10-01 - @f1nch'e 3 aylik sunucu masrafini karsiladigi icin tesekkur ederiz!
2024-09-30 - Gecici sureligine GT New Horizons sunucusu hostlayacagiz. Erisim icin Matrix'den yazin.
2024-09-01 - Bugun sunucu guncellemesi yapilacak. Birkac dakikalik erisim sikintisi olabilir.
(log sonu)])
])
