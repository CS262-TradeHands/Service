/**
 *  Type definitions for the TradeHands database
 * 
 * @author: Hayden Stob
 * @date: Fall 2025
 */

export interface Match {
    id: number;
    buyer_id: number;
    business_id: number;
    created_at: string;
}

export interface MatchInput {
    buyer_id: number;
    business_id: number;
}