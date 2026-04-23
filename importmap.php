<?php

/**
 * Returns the importmap for this application.
 *
 * - "path" is an optional relative path to the asset;
 *   it's computed from the Asset Mapper "root" dir (assets/).
 * - "entrypoint" marks this as a JavaScript entrypoint.
 *
 * For more information see: https://symfony.com/doc/current/frontend/asset_mapper.html
 */
return [
    'app' => [
        'path' => './assets/app.js',
        'entrypoint' => true,
    ],
    '@hotwired/stimulus' => [
        'version' => '3.2.2',
    ],
    '@symfony/stimulus-bundle' => [
        'path' => './vendor/symfony/stimulus-bundle/assets/dist/loader.js',
    ],
    'bootstrap' => [
        'version' => '5.3.3',
    ],
    'bootstrap/dist/css/bootstrap.min.css' => [
        'version' => '5.3.3',
        'type' => 'css',
    ],
    'alpinejs' => [
        'version' => '3.14.1',
    ],
    '@alpinejs/collapse' => [
        'version' => '3.14.1',
    ],
];
