m4_include(common.html.m4)

WEB_PAGE([
SECTION([SSS],
[> Siz kimsiniz?
Türkiye bazlı bir Linux kullanıcı grubuyuz. Matrix'te takılıp <i>cool</i> yazılımlar hostluyoruz.

> Size katılabilir miyim?
Matrix'e bekleriz. Footer'da link mevcut.])

m4_ifelse(MOBILE, 1, [], [
SECTION([SSH Parmakizleri],
[vflower:
SHA256:3J9laeo21EdP5D70CO2Jxkrexivj3iWEATJYXle9Sik (RSA)
SHA256:YTE7aW9ADbrxv+h5fZB8afBYAkePMRdSXfXHbhR61PY (ED25519)])
])

SECTION([Sunucu Logu],
[2024-10-03 - @ikolomiko'ya 2 aylık sunucu masrafını karşıladığı için teşekkür ederiz!
2024-10-01 - @f1nch'e 3 aylık sunucu masrafını karşıladığı için teşekkür ederiz!
2024-09-30 - Geçici süreliğine GT New Horizons sunucusu hostlayacağız. Erişim için Matrix'den yazın.
2024-09-01 - Bugün sunucu güncellemesi yapılacak. Birkaç dakikalık erişim sıkıntısı olabilir.
(log sonu)])
])
