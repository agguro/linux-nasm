<pre>
<?php
    $files = array("bubblesort.asm","optimizingstep0.asm","optimizingstep1.asm","optimizingstep2.asm","Makefile");
    foreach ($files as $file){
        ?>
<b><?php echo $file; ?></b><br />
<?php echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents($file))); ?>
<br />
<?php
} ?>

</pre>
