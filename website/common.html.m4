m4_changequote([, ])
m4_changecom(/*, */)

m4_ifelse(MOBILE, 1, [m4_define(WIDTH, 45)], [m4_define(WIDTH, 100)])

<!-- TODO: Nix is acting up, explicitly calling bash should not be necessary here. --->
m4_define(SECTION, [
<section>
<pre>
m4_esyscmd(cat <<M4EOF | fold -s -w WIDTH | [MOBILE]=MOBILE bash [$PWD]/aux/add-border "$1"
[$2]
M4EOF)</pre>
</section>
])

m4_define(WEB_PAGE, [
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title>TLKG - your local linux user group</title>
        m4_ifelse(MOBILE, 1, [<meta name="viewport" content="width=device-width, initial-scale=1" />])
        <link rel="stylesheet" type="text/css" href="WEB_ROOT/style.css" />
    </head>
    <body class="row-container">
        <nav>
<pre>
  tlkg hq - <a href="index.html">index</a> <s><a href="https://lists.tlkg.org.tr" style="pointer-events: none;">lists (web UI defunct)</a></s>
</pre>
        </nav>
        <main class="column-container">
            $1
        </main>
        <footer class="column-container">
<pre>
  funny copyright thingy goes here
</pre>
<div class="spacer"></div>
<pre>
<a href="https://codeberg.org/tlkg">codeberg</a> | <a href="https://matrix.to/#/%23tlkg:matrix.org">matrix</a>  
</pre>
        </footer>
    </body>
</html>
])
