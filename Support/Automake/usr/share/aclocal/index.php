<pre>
<?php
    $files = array("ax_prog_nasm.m4","ax_prog_nasm_opt.m4");
    foreach ($files as $file){
        ?>
<b><?php echo $file; ?></b><br />
<?php echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents($file))); ?>
<br />
<?php
} ?>

</pre>
