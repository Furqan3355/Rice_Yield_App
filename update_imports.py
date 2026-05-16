import os
import re

lib_dir = 'lib'

moves = [
    (r"models/auth_state\.dart", r"package:rice_yield_app/features/auth/domain/auth_state.dart"),
    (r"providers/auth_notifier\.dart", r"package:rice_yield_app/features/auth/application/auth_notifier.dart"),
    (r"services/auth_service\.dart", r"package:rice_yield_app/features/auth/application/auth_service.dart"),
]

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            new_content = content
            for old_suffix, new_import in moves:
                pattern = r"import\s+['\"][^'\"]*?" + old_suffix + r"['\"];"
                repl = r"import '" + new_import + r"';"
                new_content = re.sub(pattern, repl, new_content)

            pattern_auth = r"import\s+['\"][^'\"]*?screens/auth/([^'\"]+\.dart)['\"];"
            repl_auth = r"import 'package:rice_yield_app/features/auth/presentation/\1';"
            new_content = re.sub(pattern_auth, repl_auth, new_content)

            if new_content != content:
                print(f"Updated {filepath}")
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
