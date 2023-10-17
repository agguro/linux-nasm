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
<img width="50" height="50" src="logo.png" /><br />
<img width="150" height="50" src="picture.png" /><br />
</pre>
