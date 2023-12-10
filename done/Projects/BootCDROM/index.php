<pre>
<?php
    $files = array("make.sh");
    foreach ($files as $file){
        ?>
<b><?php echo $file; ?></b><br />
<?php echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents($file))); ?>
<br />
<?php
} ?>
<a href="bootcat/index.php">bootcat</a><br>
<a href="bootloader/index.php">bootloader</a><br>
<a href="kernel/index.php">kernel</a><br>
<a href="shell/index.php">shell</a><br>
<a href="includes/index.php">includes</a><br>
</pre>
