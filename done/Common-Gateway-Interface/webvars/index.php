<pre>
<?php
    $files = array("cgi-how-to.txt","webvars.asm","Makefile","webvars.html");
    foreach ($files as $file){
        ?>
<b><?php echo $file; ?></b><br />
<?php echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents($file))); ?>
<br />
<?php
} ?>

</pre>
