<?php

declare(strict_types=1);

namespace App\Application\Http\V1\Example;

use App\Feature\Client\Example\Request;
use App\Infrastructure\MessageBus\Symfony\MessageBus;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\MapRequestPayload;
use Symfony\Component\Routing\Attribute\Route;

use function App\env;

final class Action extends AbstractController
{
    #[Route(path: '/example', name: 'example', methods: ['POST'])]
    public function __invoke(#[MapRequestPayload] Request $request, MessageBus $messageBus): JsonResponse
    {
        return new JsonResponse([
            'version' => '1.0',
            'result' => $messageBus->execute($request),
            'env' => env("APP_ENV", ''),
        ]);
    }
}
