<?php

namespace App\DataFixtures;

use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Common\DataFixtures\DependentFixtureInterface;
use Doctrine\Persistence\ObjectManager;

/**
 * DatabaseSeeder-style orchestrator — load all fixtures in dependency order.
 *
 * Add your fixture classes to getDependencies() to ensure they run before this one.
 * This class itself can be used for any cross-fixture relationships.
 */
class AppFixtures extends Fixture implements DependentFixtureInterface
{
    public function load(ObjectManager $manager): void
    {
        // Cross-fixture setup goes here (e.g. associating related entities).
        // Individual fixtures are responsible for persisting their own entities.
    }

    public function getDependencies(): array
    {
        return [
            UserFixtures::class,
        ];
    }
}
