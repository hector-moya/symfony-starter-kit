<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20240101000000 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Create initial user table';
    }

    public function up(Schema $schema): void
    {
        // SQLite-compatible SQL. Doctrine will auto-adapt for MySQL/PostgreSQL.
        $this->addSql('CREATE TABLE "user" (
            id INTEGER NOT NULL,
            email VARCHAR(180) NOT NULL,
            name VARCHAR(100) NOT NULL,
            roles CLOB NOT NULL --(DC2Type:json)
            ,
            password VARCHAR(255) NOT NULL,
            created_at DATETIME NOT NULL --(DC2Type:datetime_immutable)
            ,
            updated_at DATETIME DEFAULT NULL --(DC2Type:datetime_immutable)
            ,
            PRIMARY KEY(id)
        )');
        $this->addSql('CREATE UNIQUE INDEX UNIQ_8D93D649E7927C74 ON "user" (email)');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('DROP TABLE "user"');
    }
}
