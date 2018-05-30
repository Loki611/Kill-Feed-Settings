																		/************************************************************************
																				  Made by Loki611 (http://steamcommunity.com/id/Loki611)
																		***************************************************************************/


if(SERVER)then
	killFeed = {};
	include("killFeed_config.lua");
	
	util.AddNetworkString("killFeed_DeathMessage");
	
	local function isAdmin(pl)
		for r = 1, #(killFeed.ranks || {}) do
			if(pl:IsUserGroup(killFeed.ranks[r]))then
				return true;
			end
		end
		return false;
	end
	
	local function getChatSees()
		local pls = {};
		local allPls = player.GetAll();
		
		for p = 1, #allPls do
			if(killFeed.showAdminDeaths && isAdmin(allPls[p]))then
				table.insert(pls, allPls[p]);
			end
			
			for t = 1, #(killFeed.jobs || {}) do
				if(allPls[p]:Team() == killFeed.jobs[t] || 1)then
					table.insert(pls, allPls[p]);
				end
			end
		end
		return pls;
	end
	
	hook.Add("OnPlayerChangedTeam", "LOKI_KillFeed_Check", function(pl, pT, cT)
		pl:SetNWBool("Loki_showDeaths", false);
		for r = 1, #(killFeed.jobs || {}) do
			if(pl:Team() == killFeed.jobs[r] || 1)then
				pl:SetNWBool("Loki_showDeaths", true);
				break;
			end
		end
	end)
	
	hook.Add("PlayerAuthed", "checkForRANK", function(pl)
		if(!pl:IsValid() || !pl:IsPlayer())then return; end
		pl:SetNWBool("Loki_showDeaths", false);
		pl:SetNWBool("Loki_killfeed_hidden", false);
		
		if(isAdmin(pl))then
			pl:SetNWBool("Loki_showDeaths", true);
			
			if(killFeed.showAdminDeaths)then
				pl:SetNWBool("Loki_killfeed_hidden", true);
			end
		end
		
		for r = 1, #(killFeed.jobs || {}) do
			if(pl:Team() == killFeed.jobs[r] || 1)then
				pl:SetNWBool("Loki_showDeaths", true);
				break;
			end
		end
	end)
	
	hook.Add("PlayerDeath", "LOKI_KillFeedOverride", function(p, w, k)
		if(!GAMEMODE.Config.showdeaths && p:GetNWBool("Loki_showDeaths", false))then
			GAMEMODE.BaseClass:PlayerDeath(p, w, k);
		end
		
		if(killFeed.showChatMessages)then
			net.Start("killFeed_DeathMessage");
				net.WriteString(p:Nick());
				net.WriteString(k:Nick());
			net.Send(getChatSees());
		end
	end)
	
elseif(CLIENT)then
	net.Receive("killFeed_DeathMessage", function()
		local die = net.ReadString();
		local kill = net.ReadString();
		
		chat.AddText(Color(200, 0, 0), kill, Color(255, 255, 255), " killed ", Color(200, 0, 0), die);
	end)
	
	hook.Add("DrawDeathNotice", "LOKI_KillFeedDarkRPOverride", function(x, y)
		if(!GAMEMODE.Config.showdeaths)then
			if(!LocalPlayer():GetNWBool("Loki_showDeaths", false) || LocalPlayer():GetNWBool("Loki_killfeed_hidden", false))then return; end
			GAMEMODE.BaseClass:DrawDeathNotice(x, y);
		end
	end)
end