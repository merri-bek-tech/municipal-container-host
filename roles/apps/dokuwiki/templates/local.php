<?php
$conf['title']    = '{{ title }}';
$conf['template']    = '{{ template }}';
$conf['userewrite']  = 1;                //this makes nice URLs: 0: off 1: .htaccess 2: internal
$conf['useslash']    = 1;                //use slash instead of colon? only when rewrite is on
$conf['sepchar']     = '_';              //word separator character in page names; may be a
                                         //  letter, a digit, '_', '-', or '.'.
$conf['useacl']      = 1;