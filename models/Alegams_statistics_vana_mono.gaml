/**
* Name: Alegams_statistics
* Author: Ligte002
* Description: 
* Tags: Tag1, Tag2, TagN
*/
model Alegams_statistics

import "./Alegams_globals.gaml"
import "./Alegams_farm.gaml"
import "./Alegams_plot.gaml"


global
{
	float avg_HH_Account;
	float std_HH_Account;
	float std_up_HH_Account;
	float std_down_HH_Account;
	float min_HH_Account;
	float max_HH_Account;
	float tot_INT;
	float tot_IE;
	float tot_IMS;
	float tot_INT_IE;
	float tot_INT_IMS;
	float tot_IE_IMS;
	float tot_reduced;
	float tot_Areamap;
	float tot_Yield_INT;
	float tot_Yield_INT_vana;
	float tot_Yield_INT_mono;
	float tot_Yield_IE;
	float tot_Yield_IMS;
	int num_INT;
	int num_IE;
	int num_IMS;
	int num_INT_IE;
	int num_INT_IMS;
	int num_IE_IMS;
	int num_Areamap;
	float chancetoReduce;
	float chancetoINT;
	float chancetoIE;
	float chancetoIMS;
	float chancetoNONE;
	float avgCosts;				
	int numberothers <- (plot count (each.color != # purple));
	action calculate_averag_HH_account
	{
		list<float> account_List <- [];
		list<float> cost_List <- [];
		ask farm
		{
			add HH_Account to: account_List;
			add costs to: cost_List;
			
		}
		avgCosts <- mean(cost_List);
		avg_HH_Account <- mean(account_List);
		std_HH_Account <- mean_deviation(account_List);
		min_HH_Account <- min(account_List);
		max_HH_Account <- max(account_List);
		std_up_HH_Account <- avg_HH_Account + std_HH_Account;
		std_down_HH_Account <- avg_HH_Account - std_HH_Account;
	}

	action calculate_yield
	{
		set tot_Yield_INT_mono <- 0.0;
		set tot_Yield_INT_vana <- 0.0;
		set tot_Yield_INT <- 0.0;
		set tot_Yield_IE <- 0.0;
		set tot_Yield_IMS <- 0.0;
		ask plot
		{
			set tot_Yield_INT <- tot_Yield_INT + yield_INT_vana + yield_INT_mono;
			set tot_Yield_INT_vana <- tot_Yield_INT_vana + yield_INT_vana;
			set tot_Yield_INT_mono <- tot_Yield_INT_mono + yield_INT_mono;
			set tot_Yield_IE <- tot_Yield_IE + yield_IE;
			set tot_Yield_IMS <- tot_Yield_IMS + yield_IMS;
		}

	}

	action calculate_tot_areas
	{
		set tot_INT <- 0.0;
		set tot_IE <- 0.0;
		set tot_IMS <- 0.0;
		set tot_reduced <- 0.0;
		//tot_Areamap <-0.0;
		//tot_INT <-   sum(plot accumulate(each.area_INT));
		//tot_IE <-   sum(plot accumulate(each.area_IE));
		//tot_IMS <-  sum(plot accumulate(each.area_IMS));
		//tot_reduced <- sum(plot accumulate(each.area_Reduced));
		ask plot
		{
			set tot_INT <- tot_INT + area_INT;
			set tot_IE <- tot_IE + area_IE;
			set tot_IMS <- tot_IMS + area_IMS;
			set tot_reduced <- tot_reduced + area_Reduced;
			tot_Areamap <- tot_Areamap + tot_Area;
		}

	}
	
	
	action calculate_relative_mutations{
		
		int nrOfReduce <- 0;
		int nrOfINT<- 0;
		int nrOfIE <- 0;
		int nrOfIMS <- 0;
		int nrOfNONE <- 0;
		int nrOfREDUCE <- 0;
		int nrOfFarms <- 0; 
		ask farm{
			nrOfFarms <- nrOfFarms + 1;
			switch changedTo
			{
				match "REDUCE"{
					nrOfREDUCE <- nrOfREDUCE + 1;

				}
				match "NONE"{
					nrOfNONE <- nrOfNONE + 1;
				}
				match "INT"{
					nrOfINT <- nrOfINT + 1;
					
				}
				match "IE"{
					nrOfIE <- nrOfIE + 1;
				}
				match "IMS"{
					nrOfIMS <- nrOfIMS + 1;
				}
				
			}
			
		}
		chancetoReduce <- nrOfREDUCE/nrOfFarms;
		chancetoINT <- nrOfINT/nrOfFarms;
		chancetoIE <- nrOfIE/nrOfFarms;
		chancetoIMS <- nrOfIMS/nrOfFarms;
		chancetoNONE <- nrOfNONE/nrOfFarms;
	}

	action calculate_num_plot
	{
		num_INT <- 0;
		num_IE <- 0;
		num_IMS <- 0;
		num_INT_IE <- 0;
		num_INT_IMS <- 0;
		num_IE_IMS <- 0;
		numberothers <- 0;
		//dummy <- 0;
		ask plot
		{
			switch production_System
			{
				match INT
				{
					num_INT <- num_INT + 1;
				}

				match IE
				{
					num_IE <- num_IE + 1;
				}

				match IMS
				{
					num_IMS <- num_IMS + 1;
				}

				match INT_IE
				{
					num_INT_IE <- num_INT_IE + 1;
				}

				match INT_IMS
				{
					num_INT_IMS <- num_INT_IMS + 1;
				}

				match IE_IMS
				{
					num_IE_IMS <- num_IE_IMS + 1;
				}

				match unKnown
				{
					numberothers <- numberothers + 1;
				}

			}

		}	

	}

	action export_maps
	{
		save plot to: "D:/UserData/results" + time + ".shp" type: "shp" with:[area_INT::'int', area_IMS::'ims', area_IE::'ie', yield_INT_mono::'Yintmono', yield_INT_vana::'Yintvana', yield_IE::'YIE', yield_IMS::'Yims', production_System::'prodsys'];
	}

	action export_spreadsheet
	{
		save [time, ST, UT, tot_INT, tot_IE, tot_IMS,num_INT,num_IE,num_IMS,num_INT_IE,num_INT_IMS,num_IE_IMS,numberothers,tot_reduced, chancetoReduce,chancetoINT,chancetoIE,chancetoIMS,chancetoNONE] to: "D:/UserData/results/resultexcel.csv" rewrite: false type: "csv";
	}

}

