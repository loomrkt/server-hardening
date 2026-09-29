.PHONY: lint syntax check apply audit
lint:    ; ansible-lint site.yml
syntax:  ; ansible-playbook site.yml --syntax-check
check:   ; ansible-playbook site.yml --check --diff
apply:   ; ansible-playbook site.yml
audit:   ; ./scripts/audit.sh
