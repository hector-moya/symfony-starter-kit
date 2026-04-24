<?php

declare(strict_types=1);

namespace App\Composer;

use Composer\Script\Event;

/**
 * Composer hooks that must run BEFORE Symfony boots (i.e., before .env is read).
 * Plain PHP only — no Symfony dependencies.
 */
final class InstallScripts
{
    public static function ensureEnv(Event $event): void
    {
        $io = $event->getIO();
        $projectDir = \dirname(__DIR__, 2);
        $env = $projectDir . '/.env';
        $example = $projectDir . '/.env.example';

        if (!file_exists($env)) {
            if (!file_exists($example)) {
                $io->writeError('<warning>.env.example missing — cannot create .env</warning>');
                return;
            }
            copy($example, $env);
            $io->write('<info>Created .env from .env.example</info>');
        }

        $contents = file_get_contents($env);
        if ($contents !== false && str_contains($contents, 'changeme_run_setup_sh_to_generate')) {
            $secret = bin2hex(random_bytes(32));
            $contents = preg_replace('/^APP_SECRET=.*/m', 'APP_SECRET=' . $secret, $contents);
            file_put_contents($env, $contents);
            $io->write('<info>Generated APP_SECRET</info>');
        }
    }
}
