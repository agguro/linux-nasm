<pre>

<b>libpyfunctions.asm</b>

<?php   
    echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents("libpyfunctions.asm")));
?>

<b>functions.py</b>

<?php
    echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents("functions.py")));
?>

<b>main.py</b>

<?php   
    echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents("main.py")));
?>

<b>Makefile</b>

<?php
    echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents("Makefile")));
?>
</pre>
