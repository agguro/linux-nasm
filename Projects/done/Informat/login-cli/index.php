<pre>
<?php
    $files = array("login-cli.asm","login-cli.inc","stringsearch.asm","section.bss.inc","section.data.inc","Makefile","section.rodata.inc");
    foreach ($files as $file){
        ?>
<b><?php echo $file; ?></b><br />
<?php echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents($file))); ?>
<br />
<?php
} ?>
</pre>
