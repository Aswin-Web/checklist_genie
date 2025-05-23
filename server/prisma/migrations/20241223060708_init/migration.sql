-- CreateTable
CREATE TABLE `User` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `email` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NULL,
    `image` VARCHAR(191) NULL,
    `created_at` DATETIME(3) NULL,

    UNIQUE INDEX `User_email_key`(`email`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Organisation` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `organisation` VARCHAR(191) NOT NULL,
    `created_at` DATETIME(3) NULL,

    UNIQUE INDEX `Organisation_organisation_key`(`organisation`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Organisation_Users` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `organisation_id` INTEGER NOT NULL,
    `user_id` INTEGER NOT NULL,
    `user_type` VARCHAR(191) NULL DEFAULT 'USER',
    `user_position` VARCHAR(191) NULL,
    `created_at` DATETIME(3) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Organisation_User_position` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `organisation_user_id` INTEGER NOT NULL,
    `user_id` INTEGER NULL,
    `user_position` ENUM('FULL_STACK_DEVELOPER', 'POWER_BI_DEVELOPER', 'SALES', 'HUMAN_RESOURCE', 'TESTING', 'SALESFORCE', 'PUBLIC') NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `tags` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `tag_name` VARCHAR(191) NOT NULL,
    `description` VARCHAR(191) NOT NULL,
    `organisation_user_id` INTEGER NOT NULL,
    `created_at` DATETIME(3) NOT NULL,
    `recurrent` BOOLEAN NOT NULL DEFAULT false,
    `user_position` ENUM('FULL_STACK_DEVELOPER', 'POWER_BI_DEVELOPER', 'SALES', 'HUMAN_RESOURCE', 'TESTING', 'SALESFORCE', 'PUBLIC') NOT NULL,

    UNIQUE INDEX `tags_tag_name_key`(`tag_name`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `checklist_template` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `template_name` VARCHAR(191) NOT NULL,
    `repeating` BOOLEAN NOT NULL DEFAULT false,
    `tag_id` INTEGER NOT NULL,
    `priority` ENUM('HIGH', 'MEDIUM', 'LOW') NOT NULL,
    `organisation_user_id` INTEGER NOT NULL,
    `created_at` DATETIME(3) NOT NULL,
    `organisation_id` INTEGER NOT NULL,
    `current_version_id` INTEGER NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `checklist_template_version` (
    `version_id` INTEGER NOT NULL AUTO_INCREMENT,
    `checklist_template_id` INTEGER NOT NULL,
    `organisation_user_id` INTEGER NOT NULL,
    `created_at` DATETIME(3) NOT NULL,

    PRIMARY KEY (`version_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `checklist_template_linked_items` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `template_version_id` INTEGER NOT NULL,
    `checklist_item_id` INTEGER NOT NULL,
    `created_at` DATETIME(3) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `checklist_template_owners` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `checklist_template_id` INTEGER NOT NULL,
    `organisation_user_id` INTEGER NOT NULL,
    `created_at` DATETIME(3) NOT NULL,

    UNIQUE INDEX `checklist_template_owners_checklist_template_id_key`(`checklist_template_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `checklist_items` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `checklist_name` VARCHAR(191) NOT NULL,
    `organisation_user_id` INTEGER NOT NULL,
    `tag_id` INTEGER NOT NULL,
    `organisation_id` INTEGER NOT NULL,
    `Instructions` VARCHAR(191) NULL,
    `input_type` ENUM('Boolean', 'Numeric') NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `checklist_item_response` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `status` BOOLEAN NULL,
    `comments` VARCHAR(191) NULL,
    `organisation_user_id` INTEGER NULL,
    `checklist_template_linked_items_id` INTEGER NULL,
    `user_assigned_checklist_template_id` INTEGER NULL,
    `template_version` INTEGER NULL,
    `selected_date` VARCHAR(191) NULL,
    `created_at` DATETIME(3) NULL,
    `input` VARCHAR(191) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `_TemplateItems` (
    `A` INTEGER NOT NULL,
    `B` INTEGER NOT NULL,

    UNIQUE INDEX `_TemplateItems_AB_unique`(`A`, `B`),
    INDEX `_TemplateItems_B_index`(`B`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `Organisation_Users` ADD CONSTRAINT `Organisation_Users_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `User`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Organisation_Users` ADD CONSTRAINT `Organisation_Users_organisation_id_fkey` FOREIGN KEY (`organisation_id`) REFERENCES `Organisation`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Organisation_User_position` ADD CONSTRAINT `Organisation_User_position_organisation_user_id_fkey` FOREIGN KEY (`organisation_user_id`) REFERENCES `Organisation_Users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Organisation_User_position` ADD CONSTRAINT `Organisation_User_position_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `User`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `tags` ADD CONSTRAINT `tags_organisation_user_id_fkey` FOREIGN KEY (`organisation_user_id`) REFERENCES `Organisation_Users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_template` ADD CONSTRAINT `checklist_template_tag_id_fkey` FOREIGN KEY (`tag_id`) REFERENCES `tags`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_template` ADD CONSTRAINT `checklist_template_organisation_user_id_fkey` FOREIGN KEY (`organisation_user_id`) REFERENCES `Organisation_Users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_template` ADD CONSTRAINT `checklist_template_organisation_id_fkey` FOREIGN KEY (`organisation_id`) REFERENCES `Organisation`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_template` ADD CONSTRAINT `checklist_template_current_version_id_fkey` FOREIGN KEY (`current_version_id`) REFERENCES `checklist_template_version`(`version_id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_template_version` ADD CONSTRAINT `checklist_template_version_checklist_template_id_fkey` FOREIGN KEY (`checklist_template_id`) REFERENCES `checklist_template`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_template_version` ADD CONSTRAINT `checklist_template_version_organisation_user_id_fkey` FOREIGN KEY (`organisation_user_id`) REFERENCES `Organisation_Users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_template_linked_items` ADD CONSTRAINT `checklist_template_linked_items_template_version_id_fkey` FOREIGN KEY (`template_version_id`) REFERENCES `checklist_template_version`(`version_id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_template_linked_items` ADD CONSTRAINT `checklist_template_linked_items_checklist_item_id_fkey` FOREIGN KEY (`checklist_item_id`) REFERENCES `checklist_items`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_template_owners` ADD CONSTRAINT `checklist_template_owners_checklist_template_id_fkey` FOREIGN KEY (`checklist_template_id`) REFERENCES `checklist_template`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_template_owners` ADD CONSTRAINT `checklist_template_owners_organisation_user_id_fkey` FOREIGN KEY (`organisation_user_id`) REFERENCES `Organisation_Users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_items` ADD CONSTRAINT `checklist_items_tag_id_fkey` FOREIGN KEY (`tag_id`) REFERENCES `tags`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_item_response` ADD CONSTRAINT `checklist_item_response_organisation_user_id_fkey` FOREIGN KEY (`organisation_user_id`) REFERENCES `Organisation_Users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_item_response` ADD CONSTRAINT `checklist_item_response_checklist_template_linked_items_id_fkey` FOREIGN KEY (`checklist_template_linked_items_id`) REFERENCES `checklist_template_linked_items`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `checklist_item_response` ADD CONSTRAINT `checklist_item_response_template_version_fkey` FOREIGN KEY (`template_version`) REFERENCES `checklist_template_version`(`version_id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `_TemplateItems` ADD CONSTRAINT `_TemplateItems_A_fkey` FOREIGN KEY (`A`) REFERENCES `checklist_items`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `_TemplateItems` ADD CONSTRAINT `_TemplateItems_B_fkey` FOREIGN KEY (`B`) REFERENCES `checklist_template`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
