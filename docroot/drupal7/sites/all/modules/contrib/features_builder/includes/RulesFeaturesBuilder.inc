<?php

class RulesFeatureBuilder extends FeaturesBuilderBase {

  public static function listFeatures() {
    return array('rules' => t('Rules'));
  }

  /**
   * {@inheritdoc}
   */
  public function package() {
    return 'Configuration';
  }

  protected function setComponents() {
    if (module_exists('rules')) {
      $this->dependencies[] = 'rules';
      $this->setAllComponents('rules_config');
      $this->setRegexComponents('variable', '/^rules_/');
    }
  }

}
