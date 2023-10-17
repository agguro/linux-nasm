<pre>
<?php
    $files = array("aggdialog.asm","Makefile");
    foreach ($files as $file){
        ?>
<b><?php echo $file; ?></b><br />
<?php echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents($file))); ?>
<br />
<?php
} ?>
<b>logo.png</b>
<img width="50" height="50" src="logo.png" /><br />
<b>
<img width="150" height="50" src="picture.png" /><br />
</pre>
