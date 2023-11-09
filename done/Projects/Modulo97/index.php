<pre>
<?php
    $files = array("libmodulo97.asm","mod97template.asm","bebankacc.asm","bedrvlic.asm","beidcard.asm","bern.asm","besiscard.asm","bevatnr.asm","structmsg.asm","Makefile");
    foreach ($files as $file){
        ?>
<b><?php echo $file; ?></b><br />
<?php echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents($file))); ?>
<br />
<?php
} ?>
</pre>
