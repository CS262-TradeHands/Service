/**
 *  Type definitions for the TradeHands database
 * 
 * @author: Hayden Stob
 * @date: Fall 2025
 */

export interface Listing {
    id: number;
    owner_id: number;
    name: string;
    industry: string;
    city: string;
    state: string;
    country: string;
    image_url?: string;
    priceUpper: number;
    priceLower: number;
    description: string;
    employees: string;
    yearOperations: number;
    annualRevenue: number;
    monthlyRevenue: number;
    profitMargin: number;
    timeline: number;
    website?: string;
    createdAt: string;
}

export interface ListingInput {
    name: string;
    industry: string;
    city: string;
    state: string;
    country: string;
    image_url?: string;
    priceUpper: number;
    priceLower: number;
    description: string;
    employees: string;
    yearOperations: number;
    annualRevenue: number;
    monthlyRevenue: number;
    profitMargin: number;
    timeline: number;
    website?: string;
}