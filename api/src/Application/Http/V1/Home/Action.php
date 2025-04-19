<?php

declare(strict_types=1);

namespace App\Application\Http\V1\Home;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;

use function App\env;

final class Action extends AbstractController
{
    #[Route(path: '/', name: 'home', methods: ['GET'])]
    public function __invoke(): JsonResponse
    {
        return new JsonResponse([
            'version' => '1.0',
            'result' => '{}',
            'env' => env("APP_ENV", ''),
        ]);
    }
}
