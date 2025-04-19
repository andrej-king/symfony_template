<?php

declare(strict_types=1);

namespace App\Feature\Client\Example;

use stdClass;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

final readonly class Handler
{
    #[AsMessageHandler]
    public function __invoke(Request $message): ?stdClass
    {
        return new Query()->getUserByEmail($message->email);
    }
}
