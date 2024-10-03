m4_include(common.html.m4)

WEB_PAGE([
SECTION([FAQ],
[> Who are you?
A Turkish linux usergroup. We hang around on Matrix, host cool software.

> Why is this site written in English?
Knowing english should be the bare minimum for messing around with computers.
Also, most of the translations of computing terms are really wacky. Don't worry,
we do talk in Turkish in the chat rooms.

> Can I join you?
Sure, come join the Matrix. Link in the footer.])

m4_ifelse(MOBILE, 1, [], [
SECTION([Server SSH Fingerprints ],
[vflower:
SHA256:3J9laeo21EdP5D70CO2Jxkrexivj3iWEATJYXle9Sik (RSA)
SHA256:YTE7aW9ADbrxv+h5fZB8afBYAkePMRdSXfXHbhR61PY (ED25519)])
])

SECTION([Server Log],
[2024-10-01 - Thanks to @f1nch for covering 3 months of server costs with their donation!
2024-09-30 - Hosting a temporary GT New Horizons server. Ask on Matrix if you want access.
2024-09-01 - Routine server upgrade. A few minutes of downtime may occur.
(end of log)])
])
