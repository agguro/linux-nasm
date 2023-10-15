<pre>
<?php
    $files = array("make.sh","main.cpp","mainwindow.cpp","mainwindow.h","mainwindow.ui","qwidgetnasm.pro");
    foreach ($files as $file){
        ?>
<b><?php echo $file; ?></b><br />
<?php echo (str_replace(array("<",">"),array("&lt;","&gt;"),file_get_contents($file))); ?>
<br />
<?php
} ?>
<a href="https://linuxnasm.be/QtCreator/qtwidgetnasm/asm/">asm</a>
<a href="https://linuxnasm.be/QtCreator/qtwidgetnasm/inc/">inc</a>
</pre>
