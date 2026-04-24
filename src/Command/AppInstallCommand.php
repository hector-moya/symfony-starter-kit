<?php

declare(strict_types=1);

namespace App\Command;

use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\ArrayInput;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\NullOutput;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

#[AsCommand(
    name: 'app:install',
    description: 'Create the database, run migrations, and load fixtures',
)]
final class AppInstallCommand extends Command
{
    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new SymfonyStyle($input, $output);
        $io->title('App install');

        $this->runChild($io, 'doctrine:database:create', ['--if-not-exists' => true], allowFailure: true);

        if (!$this->runChild($io, 'doctrine:migrations:migrate', ['--allow-no-migration' => true])) {
            $io->error('Migrations failed.');
            return Command::FAILURE;
        }

        if (!$this->runChild($io, 'doctrine:fixtures:load', [])) {
            $io->warning('Fixtures failed or bundle not installed; skipping.');
        }

        $io->success('Install complete.');
        return Command::SUCCESS;
    }

    /**
     * @param array<string, mixed> $args
     */
    private function runChild(SymfonyStyle $io, string $commandName, array $args = [], bool $allowFailure = false): bool
    {
        $application = $this->getApplication();
        if ($application === null || !$application->has($commandName)) {
            return $allowFailure;
        }

        $io->writeln(sprintf('  <info>Running %s</info>', $commandName));
        $args = array_merge(['command' => $commandName, '--no-interaction' => true], $args);
        $childInput = new ArrayInput($args);
        $childInput->setInteractive(false);

        try {
            $exitCode = $application->find($commandName)->run(
                $childInput,
                $allowFailure ? new NullOutput() : $io,
            );
        } catch (\Throwable $e) {
            if ($allowFailure) {
                return false;
            }
            $io->error($e->getMessage());
            return false;
        }

        return $exitCode === 0;
    }
}
