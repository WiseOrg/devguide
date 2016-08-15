<?php

class ServicesFeaturesBuilder extends FeaturesBuilderBase {

  public static function listFeatures() {
    return array('services' => t('Services'));
  }

  /**
   * {@inheritdoc}
   */
  public function package() {
    return 'Configuration';
  }

  protected function setComponents() {
    if (module_exists('services')) {
      $this->dependencies[] = 'services';
      $this->setAllComponents('services_endpoint');
    }
  }

}
