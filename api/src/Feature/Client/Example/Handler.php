<?php

declare(strict_types=1);

namespace App\Feature\Client\Example;

use App\Infrastructure\PasswordHasher\PasswordHasher;
use stdClass;
use Symfony\Component\Messenger\Attribute\AsMessageHandler;

final readonly class Handler
{
    public function __construct(
        private PasswordHasher $passwordHasher,
    ) {
    }

    #[AsMessageHandler]
    public function __invoke(Request $message): ?stdClass
    {
        $user = new Query()->getUserByEmail($message->email);

        if ($user === null) {
            return null;
        }

        if (!$this->passwordHasher->verify($message->password, $user->passwordHash)) {
            return null;
        }

        return $user;
    }
}
