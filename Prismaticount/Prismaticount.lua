local ADDON_NAME = 'Prismaticount';
local COMBAT_LOG_EVENT_UNFILTERED = 'COMBAT_LOG_EVENT_UNFILTERED';
local SPELL_UPDATE_COOLDOWN = 'SPELL_UPDATE_COOLDOWN';
local PRISMATIC_CRYSTAL_SPELL_ID = 155152;
local PLAYER_GUID = UnitGUID('player');

local frame = CreateFrame('FRAME', ADDON_NAME);
frame:RegisterEvent(COMBAT_LOG_EVENT_UNFILTERED);
frame:RegisterEvent(SPELL_UPDATE_COOLDOWN);

local totalDamage = 0;

local function commaValue(n) -- credit http://richard.warburton.it
	local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$');
	return left..(num:reverse():gsub('(%d%d%d)', '%1,'):reverse())..right;
end

local function eventHandler(self, event, ...)
  if (event == COMBAT_LOG_EVENT_UNFILTERED) then
    local type = select(2, ...);
    local sourceGuid = select(4, ...);
    if (type == 'SPELL_DAMAGE' and sourceGuid == PLAYER_GUID) then
      local spellId = select(12, ...);
      if (spellId == PRISMATIC_CRYSTAL_SPELL_ID) then
        if (totalDamage == 0) then
          print('Prismatic Crystal start.');
        end
        local amount = select(15, ...);
        totalDamage = totalDamage + amount;
        print(string.format('Total: %s. Your Crystal hits for %s damage.', commaValue(totalDamage), commaValue(amount)));
      end
    end
  elseif (event == SPELL_UPDATE_COOLDOWN) then
    local start, duration = GetSpellCooldown(PRISMATIC_CRYSTAL_SPELL_ID);
    if (duration == 0 and totalDamage ~= 0) then
      totalDamage = 0;
      print('Total damage has been reset.');
    end
  end
end

frame:SetScript('OnEvent', eventHandler);

print('Prismaticount initialized.');
