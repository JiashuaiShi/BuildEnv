# Development Roadmap and TODO List

## Phase 1: Environment Standardization and Enhancements

1.  **Unify Build Configurations:**
    *   Review and standardize build configurations across all modules (`alma9`, `ubuntu/dev`, `systemd/*`, etc.).
    *   Eliminate unnecessary differences in Dockerfiles and `docker-compose.yaml` files.
    *   Ensure consistent use of base images, user setups, and common scripts.

2.  **Improve Password Management:**
    *   Remove hardcoded passwords from scripts (`2-dev-cli.sh`) and `docker-compose.yaml` environment variables.
    *   Investigate and implement a more secure method for managing secrets/passwords in development environments (e.g., using `.env` files with gitignore, or exploring Docker secrets if appropriate for the dev setup).

3.  **Enhance Chinese Language Support:**
    *   **Fonts:** Research and integrate better, more comprehensive Chinese font packages into the base images to ensure proper display of all CJK characters in terminal and potential GUI applications.
    *   **Locale:** Verify `LANG=zh_CN.UTF-8` and `LC_ALL=zh_CN.UTF-8` are consistently applied and effective.

4.  **Optimize APT/DNF Repository Configuration:**
    *   **Mirror Usage:** Standardize the use of reliable Chinese mirror sources (e.g., Aliyun, TUNA) for APT (Ubuntu) and DNF (AlmaLinux) to improve download speeds.
    *   **GPG Key Issues:** Investigate and resolve any recurring GPG key validation errors during package installation. Ensure all keys for mirrors are correctly imported and trusted.

## Phase 2: Expanding Development Capabilities

5.  **Broaden Environment Support:**
    *   **Frontend Development:** Add support for common frontend development tools and runtimes (e.g., Node.js, npm/yarn, browser debugging tools if feasible within a containerized setup).
    *   **Other Languages/Frameworks:** Consider adding pre-configured environments for other languages or frameworks based on anticipated needs.

## Future Considerations / Ideas

*   **IDE Integration:** Improve and document IDE integration (VSCode Dev Containers, CLion remote dev) for a smoother developer experience.
*   **Testing Frameworks:** Integrate common testing frameworks relevant to the supported languages.
*   **Performance Optimization:** Continuously review and optimize image build times and container startup times.
*   **Documentation:** Keep all README files and the ROADMAP updated. 