<?php
declare(strict_types=1);

$phpVersion = PHP_VERSION;
$serverTime = date('Y-m-d H:i:s');
$extensions = [
    'curl',
    'mbstring',
    'openssl',
    'pdo_sqlite',
    'zip',
    'xml'
];

function checkExtension(string $name): string {
    return extension_loaded($name)
        ? 'Installed'
        : 'Not installed';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1">
    <title>Render PHP Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #0f172a;
            color: #f8fafc;
            margin: 0;
            padding: 40px 20px;
        }
        .container {
            max-width: 650px;
            margin: 40px auto;
            background: #1e293b;
            border-radius: 16px;
            padding: 32px;
        }
        h1 { color: #38bdf8; }
        .status { color: #4ade80; }
        .item {
            padding: 12px 0;
            border-bottom: 1px solid #334155;
        }
        .item span { float: right; }
        a { color: #38bdf8; }
    </style>
</head>
<body>
<div class="container">
    <h1>PHP Server Render</h1>
    <p class="status">PHP is running successfully!</p>

    <div class="item">
        PHP Version
        <span><?= htmlspecialchars($phpVersion) ?></span>
    </div>

    <div class="item">
        Server Time
        <span><?= htmlspecialchars($serverTime) ?></span>
    </div>

    <h2>PHP Extensions</h2>

    <?php foreach ($extensions as $extension): ?>
        <div class="item">
            <?= htmlspecialchars($extension) ?>
            <span><?= checkExtension($extension) ?></span>
        </div>
    <?php endforeach; ?>

    <p>Powered by PHP, Nginx and Render.</p>
</div>
</body>
</html>
