<?php

namespace App\DataFixtures;

use App\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

class UserFixtures extends Fixture
{
    public const ADMIN_REFERENCE = 'user-admin';

    public function __construct(
        private readonly UserPasswordHasherInterface $passwordHasher,
    ) {}

    public function load(ObjectManager $manager): void
    {
        $faker = Factory::create();

        // Create a known admin user for easy testing
        $admin = new User();
        $admin->setEmail('admin@example.com');
        $admin->setName('Admin User');
        $admin->setRoles(['ROLE_ADMIN']);
        $admin->setPassword($this->passwordHasher->hashPassword($admin, 'password'));
        $manager->persist($admin);
        $this->addReference(self::ADMIN_REFERENCE, $admin);

        // Create 10 random users
        for ($i = 0; $i < 10; ++$i) {
            $user = new User();
            $user->setEmail($faker->unique()->safeEmail());
            $user->setName($faker->name());
            $user->setRoles(['ROLE_USER']);
            $user->setPassword($this->passwordHasher->hashPassword($user, 'password'));
            $manager->persist($user);
        }

        $manager->flush();
    }
}
