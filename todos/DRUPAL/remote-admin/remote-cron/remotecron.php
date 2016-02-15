<?php

/**
 * @file
 * Handles incoming requests to fire off regularly-scheduled tasks (cron jobs).
 * remotely.
 */

define('DRUPAL_ROOT', getcwd());

include_once DRUPAL_ROOT . '/includes/bootstrap.inc';
drupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);

if (!isset($_POST['cron_key']) || variable_get('cron_key', 'drupal') != $_POST['cron_key']) {
  watchdog('cron', 'Remote cron FAILED - invalid key.', array(), WATCHDOG_NOTICE);
  echo "access denied\n";
}
elseif (variable_get('maintenance_mode', 0)) {
  watchdog('cron', 'Remote cron ABORTED - site in maintenance mode.', array(), WATCHDOG_NOTICE);
  echo "site in maintenance mode. cron aborted\n";
}
else {
  drupal_cron_run();
  watchdog('cron', 'Remote cron SUCCES', array(), WATCHDOG_NOTICE);
  echo "cron succes\n";
}