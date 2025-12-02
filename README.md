# BubbleCat
BubbleCat: Endless Flyer, Este projeto é um jogo de plataforma 2D no estilo endless flyer (corredor infinito), inspirado em Flappy Bird, desenvolvido na Godot Engine utilizando a linguagem GDScript.  O jogo se destaca por introduzir mecânicas de progressão de fase e diferentes tipos de inimigos, mantendo o estilo visual vibrante e em pixel art.

⚙️ Tecnologias e Linguagem
Motor do Jogo: Godot Engine 4.x

Linguagem Principal: GDScript

Plataforma: Desktop, Web e Mobile (multi-plataforma).

🎮 Funcionalidades Principais
Progressão de Fase: O jogo possui transição dinâmica de fases (Fase 1, Fase 2 com Birds, Fase 3 com enemybird e o Portal próxima fase), ativada ao atingir pontuações específicas.

Transições Suaves: Implementação de um efeito Fade-to-Black (Escurecer para Preto) para garantir transições de fase suaves e polidas, utilizando a funcionalidade Tween do Godot ainda em andamento.

Mecânica de Escudo: O jogador (BubbleCat/Bird) pode ganhar um escudo de proteção temporário ao atingir múltiplos de 10 pontos.

Sistema de Pontuação e Recorde: Gerenciamento global de pontuação e registro do Recorde Pessoal (High Score) usando o nó Singleton (GameManager).

Inimigos Variados: Implementação de diferentes tipos de inimigos (Spawners dedicados) por fase para criar desafios distintos.
