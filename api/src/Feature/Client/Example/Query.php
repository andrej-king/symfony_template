<?php

declare(strict_types=1);

namespace App\Feature\Client\Example;

use stdClass;

final readonly class Query
{
    public function getUserByEmail(string $email): ?stdClass
    {
        $email = strtolower($email);

        $tempUserExample = new stdClass();
        $tempUserExample->login = 'test';
        $tempUserExample->email = 'test@example.com';
        $tempUserExample->firstName = 'John';
        $tempUserExample->lastName = 'Doe';

        return $tempUserExample->email === $email ? $tempUserExample : null;
    }
}
