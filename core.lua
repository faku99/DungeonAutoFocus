local ADDON, Addon = ...

local BUTTON_NAME = ADDON .. 'PopupSecureButton';
local DIALOG_NAME = ADDON .. 'Dialog';
local LISTENER_NAME = ADDON .. 'Listener';

local listener = CreateFrame('Frame', LISTENER_NAME);
listener:RegisterEvent("PLAYER_ENTERING_WORLD");

-- This dialog will show up when entering an instance with a group of 2-5 people.
StaticPopupDialogs[DIALOG_NAME] = {
    text = 'Do you want to focus %s-%s?',
    button1 = 'Yes',
    button2 = 'No',
    OnShow = function(self)
        -- Retrieve tank name from argument
        local unit = self.text.text_arg1;

        -- Create SecureAction button and set same cosmetics as StaticPopupButtonTemplate
        self.secureButton = CreateFrame('Button', BUTTON_NAME, self, 'SecureActionButtonTemplate');
        --  Position
        self.secureButton:SetSize(self.button1:GetSize());
        self.secureButton:SetPoint(self.button1:GetPoint());
        --  Text
        self.secureButton:SetText(self.button1:GetText());
        --  Textures
        self.secureButton:SetNormalTexture(self.button1:GetNormalTexture());
        self.secureButton:SetHighlightTexture(self.button1:GetHighlightTexture());
        self.secureButton:SetPushedTexture(self.button1:GetPushedTexture());
        --  Fonts
        self.secureButton:SetNormalFontObject(GameFontNormal);
        self.secureButton:SetDisabledFontObject(GameFontDisable);
        self.secureButton:SetHighlightFontObject(GameFontHighlight);

        -- Set focus action
        self.secureButton:SetAttribute('type1', 'focus');
        self.secureButton:SetAttribute('unit1', unit);

        -- Don't forget to hide the origin 'YES' button
        self.button1:Hide();
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

-- Hook this function in order to know then PopupSecureButton has been pressed. On click, hide the static popup.
hooksecurefunc('SecureActionButton_OnClick',
    function(self, _)
        if (self:GetName() == BUTTON_NAME) then
            StaticPopup_Hide(DIALOG_NAME);
        end
    end
);

-- Addon's general printing function.
function Addon:Print(message)
    print(ADDON .. ' - ' .. message);
end

-- Addon's general warning printing function.
function Addon:PrintWarning(message)
    Addon:Print('|cFFFF00FFWARNING:|r ' .. message);
end

local function getPlayerName(unit)
    local name, realm = UnitName(unit);

    if (realm == nil) then
        realm = GetRealmName();
    end

    return name, realm;
end

local function onEvent(self, event, ...)
    if (event == 'PLAYER_ENTERING_WORLD') then
        local _, instanceType, _ = GetInstanceInfo();

        if (instanceType == 'party') then
            local numGroupMembers = GetNumGroupMembers();
            if (numGroupMembers > 0) then
                local tankFound = false;
                -- Iterate over party members to find who's tanking
                for i = 1, numGroupMembers - 1 do
                    local unit = 'party' .. i;
                    local role = UnitGroupRolesAssigned(unit);
                    local name, realm = getPlayerName(unit);

                    if (role == 'TANK') then
                        tankFound = true;
                        if (UnitName('focus') == 'none') then
                            StaticPopup_Show(DIALOG_NAME, name, realm);
                        else
                            Addon:PrintWarning('Already focusing ' .. UnitName('focus'));
                        end
                    end
                end

                if (tankFound == false) then
                    Addon:PrintWarning('No tank found!');
                end
            end
        end
    end
end

listener:SetScript("OnEvent", onEvent);
