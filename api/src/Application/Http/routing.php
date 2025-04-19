<?php

declare(strict_types=1);

namespace App\Application\Http;

use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;

/**
 * Create alias for latest value
 */
return static function (RoutingConfigurator $routing): void {
    // TODO create last api version constant
    $routing
        ->import(__DIR__ . '/V1', 'attribute')
        ->prefix($prefix = '/latest', false)
        ->namePrefix('latest_')
        ->defaults(['prefix' => $prefix]);
//        ->format('json');
};
