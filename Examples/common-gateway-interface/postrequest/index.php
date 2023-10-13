<pre>
<?php
    $files = array("postrequest-how-to.txt","postrequest.asm","Makefile","postrequest.html");
    foreach ($files as $file){
        ?>
<b><?php echo $file; ?></b><br />
<?php echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents($file))); ?>
<br />
<?php
} ?>

</pre>
