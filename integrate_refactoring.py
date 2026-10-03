from __future__ import annotations

import argparse
import shutil
import sys
from datetime import datetime
from pathlib import Path


# ============================================================
# CONFIGURAÇÃO
# ============================================================

FILES_TO_INSTALL = {
    # UI Scripts
    "main_battle_ui.gd": "scripts/ui/main_battle_ui.gd",
    "character_layer.gd": "scripts/ui/character_layer.gd",
    "status_layer.gd": "scripts/ui/status_layer.gd",
    "action_layer.gd": "scripts/ui/action_layer.gd",
    "information_layer.gd": "scripts/ui/information_layer.gd",
    "mock_data.gd": "scripts/ui/mock_data.gd",
    "battle_stage_art.gd": "scripts/ui/battle_stage_art.gd",
    "battle_theme.gd": "scripts/ui/battle_theme.gd",
    "combat_log.gd": "scripts/ui/combat_log.gd",
    "combat_menu.gd": "scripts/ui/combat_menu.gd",
    "portrait_slot.gd": "scripts/ui/portrait_slot.gd",
    "scene_backdrop.gd": "scripts/ui/scene_backdrop.gd",
    "skill_tree.gd": "scripts/ui/skill_tree.gd",
    "skill_tree_node.gd": "scripts/ui/skill_tree_node.gd",
    "status_bar.gd": "scripts/ui/status_bar.gd",

    # Battle
    "battle_ui_refactored.tscn": "scenes/battle/battle_ui_refactored.tscn",
    "battle.tscn": "scenes/battle/battle.tscn",
    "battle.gd": "scripts/battle/battle.gd",
    "battle_combatant.gd": "scripts/battle/battle_combatant.gd",
    "battle_skills.gd": "scripts/battle/battle_skills.gd",

    # Core / Managers
    "constants.gd": "scripts/core/constants.gd",
    "game_manager.gd": "scripts/core/game_manager.gd",
    "game_state.gd": "scripts/core/game_state.gd",
    "scene_manager.gd": "scripts/core/scene_manager.gd",

    # Characters
    "character_base.gd": "scripts/character/character_base.gd",
    "player_character.gd": "scripts/character/player_character.gd",

    # Narrative / Dialogue
    "dialogue_manager.gd": "scripts/narrative/dialogue_manager.gd",
    "dialogue_ui.gd": "scenes/ui/dialogue_ui.gd",
    "dialogue_ui.tscn": "scenes/ui/dialogue_ui.tscn",

    # Resources
    "item_data.gd": "scripts/resources/item_data.gd",
    "skill_data.gd": "scripts/resources/skill_data.gd",

    # Scenes (Boot, Menu, World)
    "boot.gd": "scenes/boot/boot.gd",
    "boot.tscn": "scenes/boot/boot.tscn",
    "main_menu.gd": "scenes/menu/main_menu.gd",
    "main_menu.tscn": "scenes/menu/main_menu.tscn",
    "world_map.gd": "scenes/world/world_map.gd",
    "world_map.tscn": "scenes/world/world_map.tscn",
    
    # Raiz
    "main.tscn": "main.tscn",

    # Tests
    "battle_check.gd": "tests/battle_check.gd",
    "battle_test.tscn": "tests/battle_test.tscn",
    "screenshot.gd": "tests/screenshot.gd",
    "screenshot.tscn": "tests/screenshot.tscn",
}


# ============================================================
# CORES / LOG
# ============================================================

class Log:
    RESET = "\033[0m"
    GREEN = "\033[92m"
    RED = "\033[91m"
    YELLOW = "\033[93m"
    CYAN = "\033[96m"
    WHITE = "\033[97m"

    @staticmethod
    def info(message: str):
        print(f"{Log.CYAN}[INFO]{Log.RESET} {message}")

    @staticmethod
    def ok(message: str):
        print(f"{Log.GREEN}[OK]{Log.RESET}   {message}")

    @staticmethod
    def warning(message: str):
        print(f"{Log.YELLOW}[WARN]{Log.RESET} {message}")

    @staticmethod
    def error(message: str):
        print(f"{Log.RED}[ERROR]{Log.RESET} {message}")

    @staticmethod
    def line():
        print("-" * 70)


# ============================================================
# LOCALIZAÇÃO DOS ARQUIVOS
# ============================================================

def find_file(source_dir: Path, filename: str) -> Path | None:
    """
    Procura um arquivo pelo nome em toda a árvore de diretórios.

    Funciona tanto para:

        files/
            main_battle_ui.gd

    quanto:

        files/
            qualquer_pasta/
                scripts/
                    ui/
                        main_battle_ui.gd
    """

    # Primeiro procura diretamente na raiz.
    direct = source_dir / filename

    if direct.is_file():
        return direct

    # Depois procura recursivamente.
    matches = list(source_dir.rglob(filename))

    if not matches:
        return None

    if len(matches) == 1:
        return matches[0]

    # Se houver múltiplos arquivos com o mesmo nome,
    # tenta escolher o caminho mais compatível.
    preferred = []

    for match in matches:
        normalized = str(match).replace("\\", "/").lower()

        if filename == "main_battle_ui.gd" and "/scripts/ui/" in normalized:
            preferred.append(match)

        elif filename in {
            "character_layer.gd",
            "status_layer.gd",
            "action_layer.gd",
            "information_layer.gd",
            "mock_data.gd",
        } and "/scripts/ui/" in normalized:
            preferred.append(match)

        elif filename == "battle_ui_refactored.tscn" and "/scenes/battle/" in normalized:
            preferred.append(match)

    if len(preferred) == 1:
        return preferred[0]

    # Se ainda houver ambiguidade, usa o primeiro e avisa.
    Log.warning(
        f"Múltiplos arquivos encontrados para '{filename}'. "
        f"Usando: {matches[0]}"
    )

    return matches[0]


# ============================================================
# BACKUP
# ============================================================

def create_backup(
    project_dir: Path,
    target_file: Path,
    backup_root: Path,
) -> Path | None:

    if not target_file.exists():
        return None

    relative = target_file.relative_to(project_dir)
    backup_file = backup_root / relative

    backup_file.parent.mkdir(parents=True, exist_ok=True)

    shutil.copy2(target_file, backup_file)

    return backup_file


# ============================================================
# INSTALAÇÃO
# ============================================================

def install_file(
    source_file: Path,
    project_dir: Path,
    relative_destination: str,
    overwrite: bool,
    backup_root: Path | None,
) -> tuple[bool, str]:

    destination = project_dir / relative_destination

    destination.parent.mkdir(parents=True, exist_ok=True)

    # --------------------------------------------------------
    # Arquivo já existe
    # --------------------------------------------------------

    if destination.exists():

        if not overwrite:
            return (
                False,
                f"Destino já existe: {destination}"
            )

        if backup_root is not None:
            backup_file = create_backup(
                project_dir,
                destination,
                backup_root,
            )

            if backup_file:
                Log.ok(
                    f"Backup criado: "
                    f"{backup_file.relative_to(backup_root)}"
                )

    # --------------------------------------------------------
    # Copiar
    # --------------------------------------------------------

    shutil.copy2(source_file, destination)

    return True, str(destination)


# ============================================================
# RELATÓRIO
# ============================================================

def write_report(
    project_dir: Path,
    source_dir: Path,
    installed: list[tuple[str, str]],
    skipped: list[str],
    missing: list[str],
    backup_root: Path | None,
):

    report = project_dir / "INTEGRATION_REPORT.txt"

    with report.open(
        "w",
        encoding="utf-8",
    ) as file:

        file.write("ECOS DO ENCANTADO\n")
        file.write("INTEGRAÇÃO DA UI REFATORADA\n")
        file.write("=" * 70 + "\n\n")

        file.write(
            f"Data: "
            f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
        )

        file.write(f"Origem: {source_dir}\n")
        file.write(f"Destino: {project_dir}\n\n")

        file.write("ARQUIVOS INSTALADOS\n")
        file.write("-" * 70 + "\n")

        for source, destination in installed:
            file.write(
                f"[OK] {source} -> {destination}\n"
            )

        file.write("\n")

        file.write("ARQUIVOS IGNORADOS\n")
        file.write("-" * 70 + "\n")

        if skipped:
            for item in skipped:
                file.write(f"[SKIP] {item}\n")
        else:
            file.write("Nenhum arquivo ignorado.\n")

        file.write("\n")

        file.write("ARQUIVOS NÃO ENCONTRADOS\n")
        file.write("-" * 70 + "\n")

        if missing:
            for item in missing:
                file.write(f"[MISSING] {item}\n")
        else:
            file.write("Nenhum arquivo ausente.\n")

        file.write("\n")

        if backup_root:
            file.write(
                f"BACKUP:\n{backup_root}\n"
            )

    return report


# ============================================================
# MAIN
# ============================================================

def main():

    parser = argparse.ArgumentParser(
        description=(
            "Integra a UI refatorada do Ecos do Encantado "
            "ao projeto Godot."
        )
    )

    parser.add_argument(
        "--source-path",
        required=True,
        help=(
            "Pasta onde estão os arquivos da refatoração. "
            "Os arquivos podem estar soltos ou em subpastas."
        ),
    )

    parser.add_argument(
        "--project-path",
        required=True,
        help="Pasta raiz do projeto Godot.",
    )

    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Substitui arquivos existentes.",
    )

    parser.add_argument(
        "--no-backup",
        action="store_true",
        help="Não cria backup dos arquivos substituídos.",
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Apenas mostra o que seria feito.",
    )

    args = parser.parse_args()

    source_dir = Path(args.source_path).resolve()
    project_dir = Path(args.project_path).resolve()

    # ========================================================
    # HEADER
    # ========================================================

    print()
    Log.info("ECOS DO ENCANTADO")
    Log.info("Integração da UI Refatorada")
    Log.line()

    # ========================================================
    # VALIDAR PROJETO
    # ========================================================

    project_file = project_dir / "project.godot"

    if not project_file.exists():
        Log.error(
            f"Projeto Godot não encontrado: {project_dir}"
        )
        Log.error(
            "O arquivo project.godot não foi localizado."
        )
        sys.exit(1)

    Log.ok(
        f"Projeto Godot encontrado: {project_dir}"
    )

    # ========================================================
    # VALIDAR SOURCE
    # ========================================================

    if not source_dir.exists():
        Log.error(
            f"Pasta de origem não encontrada: {source_dir}"
        )
        sys.exit(1)

    if not source_dir.is_dir():
        Log.error(
            f"O caminho de origem não é uma pasta: {source_dir}"
        )
        sys.exit(1)

    Log.info(
        f"Verificando arquivos de origem: {source_dir}"
    )

    # ========================================================
    # LOCALIZAR ARQUIVOS
    # ========================================================

    found_files: dict[str, Path] = {}
    missing_files: list[str] = []

    for filename in FILES_TO_INSTALL:

        found = find_file(
            source_dir,
            filename,
        )

        if found is None:
            missing_files.append(filename)

        else:
            found_files[filename] = found

            relative = found.relative_to(source_dir)

            Log.ok(
                f"{filename} encontrado em: {relative}"
            )

    print()

    # ========================================================
    # RESUMO
    # ========================================================

    Log.info(
        f"Arquivos encontrados: "
        f"{len(found_files)}/{len(FILES_TO_INSTALL)}"
    )

    if missing_files:

        Log.warning(
            f"Arquivos não encontrados: "
            f"{len(missing_files)}"
        )

        for filename in missing_files:
            Log.warning(
                f"  - {filename}"
            )

    if not found_files:
        Log.error(
            "Nenhum arquivo da refatoração foi encontrado."
        )
        sys.exit(1)

    # ========================================================
    # DRY RUN
    # ========================================================

    if args.dry_run:

        print()
        Log.info("DRY-RUN: nenhuma alteração será realizada.")
        Log.line()

        for filename, source_file in found_files.items():

            destination = (
                project_dir /
                FILES_TO_INSTALL[filename]
            )

            print(
                f"[DRY-RUN] "
                f"{source_file} "
                f"-> "
                f"{destination}"
            )

        print()
        Log.ok("Dry-run concluído.")
        return

    # ========================================================
    # BACKUP
    # ========================================================

    backup_root = None

    if args.overwrite and not args.no_backup:

        timestamp = datetime.now().strftime(
            "%Y%m%d_%H%M%S"
        )

        backup_root = (
            project_dir /
            "_refactoring_backup" /
            timestamp
        )

        backup_root.mkdir(
            parents=True,
            exist_ok=True,
        )

        Log.info(
            f"Backup habilitado: {backup_root}"
        )

    # ========================================================
    # COPIAR
    # ========================================================

    installed = []
    skipped = []
    errors = []

    print()

    Log.info("Integrando arquivos...")
    Log.line()

    for filename, source_file in found_files.items():

        relative_destination = FILES_TO_INSTALL[
            filename
        ]

        destination = (
            project_dir /
            relative_destination
        )

        # ----------------------------------------------------
        # Não sobrescrever
        # ----------------------------------------------------

        if destination.exists() and not args.overwrite:

            Log.warning(
                f"Ignorado: {relative_destination}"
            )

            skipped.append(
                relative_destination
            )

            continue

        try:

            success, result = install_file(
                source_file=source_file,
                project_dir=project_dir,
                relative_destination=relative_destination,
                overwrite=args.overwrite,
                backup_root=backup_root,
            )

            if success:

                Log.ok(
                    f"{filename} -> "
                    f"{relative_destination}"
                )

                installed.append(
                    (
                        str(
                            source_file.relative_to(
                                source_dir
                            )
                        ),
                        relative_destination,
                    )
                )

        except Exception as exc:

            Log.error(
                f"Falha ao copiar {filename}: {exc}"
            )

            errors.append(
                f"{filename}: {exc}"
            )

    # ========================================================
    # RELATÓRIO
    # ========================================================

    report = write_report(
        project_dir=project_dir,
        source_dir=source_dir,
        installed=installed,
        skipped=skipped,
        missing=missing_files,
        backup_root=backup_root,
    )

    # ========================================================
    # FINAL
    # ========================================================

    print()
    Log.line()

    Log.info("RESUMO DA INTEGRAÇÃO")

    print(
        f"  Encontrados : {len(found_files)}"
    )

    print(
        f"  Instalados  : {len(installed)}"
    )

    print(
        f"  Ignorados   : {len(skipped)}"
    )

    print(
        f"  Ausentes    : {len(missing_files)}"
    )

    print(
        f"  Erros       : {len(errors)}"
    )

    print()

    Log.info(
        f"Relatório: {report}"
    )

    if backup_root:
        Log.info(
            f"Backup: {backup_root}"
        )

    if errors:

        Log.error(
            "A integração terminou com erros."
        )

        sys.exit(1)

    if missing_files:

        Log.warning(
            "A integração terminou, mas existem "
            "arquivos não encontrados."
        )

    else:

        Log.ok(
            "Integração concluída com sucesso!"
        )


if __name__ == "__main__":
    main()
