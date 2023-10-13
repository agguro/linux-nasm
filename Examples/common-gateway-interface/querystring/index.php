<pre>
<?php
    $files = array("querystring-how-to.txt","querystring.asm","Makefile","querystring.html");
    foreach ($files as $file){
        ?>
<b><?php echo $file; ?></b><br />
<?php echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents($file))); ?>
<br />
<?php
} ?>

</pre>
