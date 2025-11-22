/**
 *  Type definitions for the TradeHands database
 * 
 * @author: Hayden Stob
 * @date: Fall 2025
 */

export interface User {
    id: number;
    first_name: string;
    last_name: string;
    email: string;
    phone?: string;
    passwordHash: string;
    profileImgUrl?: string;
    verified: boolean;
    private: boolean;
    createdAt: string;
}

export interface UserInput {
    first_name: string;
    last_name: string;
    email: string;
    phone?: string;
    passwordHash: string;
    profileImgUrl?: string;
}