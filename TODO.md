# Task: Toggle para desabilitar karma + notificações no chat

- [x] Plano aprovado
- [ ] Criar convar `zb_karma_enabled` em shared.lua (default 1)
- [ ] Editar sv_guilt.lua: IsKarmaEnabled() = convar:GetBool(); early return no GuiltReg se disabled
- [ ] Adicionar ChatPrint em mudanças de Karma (Attacker.Karma = ...)
- [ ] Comando admin !karma para toggle
- [ ] Testar toggle e notificações

