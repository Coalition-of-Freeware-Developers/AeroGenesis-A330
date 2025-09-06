jit.off()
-- (c)2025 Luka Nöckel @quackderbruchpilot_ for AeroGenesis A330

A333_ewd_msg.ADIRS_ALIGN = newEWDwarningMessage('ADIRS_ALIGN', 'NAV', 'NAV', 'ADIRS ALIGN', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1010)
A333_ewd_msg.ADIRS_ALIGN.Inhibit = {1,1,1,1,1,0,1,1,1,1}
A333_ewd_msg.ADIRS_ALIGN.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.SLATS_CONFIG.MsgLine = {
	{MsgColor = 0, MsgText = 'ADIRS ALIGN', MsgVisible = 1, MsgCleared = 0, MsgStatus = 0},
}