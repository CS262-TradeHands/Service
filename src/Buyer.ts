/**
 *  Type definitions for the TradeHands database
 * 
 * @author: Hayden Stob
 * @date: Fall 2025
 */

export interface Buyer {
    id: number;
    user_id: number;
    title: string;
    about: string;
    experience: number;
    budgetLow: number;
    budgetHigh: number;
    city: string;
    state: string;
    country: string;
    industries: string[];
    sizePreferences: string;
    timeline: number;
    linkedIn: string;
    createdAt: string;
}

export interface BuyerInput {
    title: string;
    about: string;
    experience: number;
    budgetLow: number;
    budgetHigh: number;
    city: string;
    state: string;
    country: string;
    industries: string[];
    sizePreferences: string;
    timeline: number;
    linkedIn?: string;
}