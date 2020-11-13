import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class DemandSpec: QuickSpec {
    
    typealias Demand = Subscribers.Demand
    
    override func spec() {
        
        // MARK: - Create
        describe("Create") {
            
            #if arch(x86_64) && canImport(Darwin)
            // MARK: 1.1 should fatal error when create with negative number
            it("should fatal error when create with negative number") {
                expect {
                    _ = Demand.max(-1)
                }.to(throwAssertion())
            }
            #endif
        }
        
        // MARK: - Calculate
        describe("Calculate") {
            
            // MARK: 2.1 should add as expected
            it("should add as expected") {
                expect(Demand.max(1) + Demand.max(1)) == .max(2)
                expect(Demand.max(1) + 1) == .max(2)
                expect(Demand.max(1) + Demand.unlimited) == .unlimited
                expect(Demand.max(1) + (-1)) == .max(0)
                
                expect(Demand.unlimited + 1) == .unlimited
                expect(Demand.unlimited + .unlimited) == .unlimited
                
                expect(Demand.max(1) + Demand.max(.max)) == .unlimited
                
                var d = Demand.max(1)
                d += .max(2)
                expect(d) == .max(3)
                d += 3
                expect(d) == .max(6)
                d += .unlimited
                expect(d) == .unlimited
                d += Int.max
                expect(d) == .unlimited
                d += Int.min
                expect(d) == .unlimited
                d += 42
                expect(d) == .unlimited
                
            }
            
            // MARK: 2.2 should sub as expected
            it("should sub as expected") {
                expect(Demand.max(2) - Demand.max(1)) == .max(1)
                expect(Demand.max(2) - 1) == .max(1)
                expect(Demand.max(1) - Demand.unlimited) == .max(0)
                expect(Demand.max(1) - 1) == .max(0)
                expect(Demand.unlimited - Demand.max(1)) == .unlimited
                expect(Demand.unlimited - Demand.unlimited) == .unlimited
                
                var d = Demand.max(10)
                d -= .max(1)
                expect(d) == .max(9)
                d -= .max(2)
                expect(d) == .max(7)
                d -= 3
                expect(d) == .max(4)
                d -= (-1)
                expect(d) == .max(5)
                d -= .unlimited
                expect(d) == .max(0)
                
                d = .unlimited
                d -= .max(1)
                expect(d) == .unlimited
                d -= .max(.max)
                expect(d) == .unlimited
                d -= Int.max
                expect(d) == .unlimited
                d -= (-1)
                expect(d) == .unlimited
                d -= Int.min
                expect(d) == .unlimited
                d -= .unlimited
                expect(d) == .unlimited
            }
            
            // MARK: 2.3 should multiply as expected
            it("should multiply as expected") {
                expect(Demand.max(1) * 7) == .max(7)
                expect(Demand.max(.max) * 2) == .unlimited
                
                expect(Demand.unlimited * 2) == .unlimited
                expect(Demand.unlimited * Int.max) == .unlimited
                expect(Demand.unlimited * 0) == .unlimited
                
                var d = Demand.max(5)
                d *= 1
                expect(d) == .max(5)
                d *= 2
                expect(d) == .max(10)
                d *= Int.max
                expect(d) == .unlimited
                d *= 42
                expect(d) == .unlimited
                d *= 0
                expect(d) == .unlimited
                
                #if arch(x86_64) && canImport(Darwin)
                expect {
                    _ = Demand.max(1) * -1
                }.to(throwAssertion())
                #endif
            }
        }
        
        // MARK: - Compare
        describe("Compare") {
            
            // MARK: 3.1 should compare as expecte
            it("should compare as expected") {
                expect(Demand.unlimited == .unlimited) == true
                expect(Demand.unlimited != .unlimited) == false
                expect(Demand.unlimited <  .unlimited) == false
                expect(Demand.unlimited <= .unlimited) == true
                expect(Demand.unlimited >= .unlimited) == true
                expect(Demand.unlimited >  .unlimited) == false

                expect(Demand.unlimited == .max(42)) == false
                expect(Demand.unlimited != .max(42)) == true
                expect(Demand.unlimited <  .max(42)) == false
                expect(Demand.unlimited <= .max(42)) == false
                expect(Demand.unlimited >= .max(42)) == true
                expect(Demand.unlimited >  .max(42)) == true
                expect(Demand.unlimited == 42) == false
                expect(Demand.unlimited != 42) == true
                expect(Demand.unlimited <  42) == false
                expect(Demand.unlimited <= 42) == false
                expect(Demand.unlimited >= 42) == true
                expect(Demand.unlimited >  42) == true

                expect(Demand.max(42) == .unlimited) == false
                expect(Demand.max(42) != .unlimited) == true
                expect(Demand.max(42) <  .unlimited) == true
                expect(Demand.max(42) <= .unlimited) == true
                expect(Demand.max(42) >= .unlimited) == false
                expect(Demand.max(42) >  .unlimited) == false
                expect(42 == Demand.unlimited) == false
                expect(42 != Demand.unlimited) == true
                expect(42 <  Demand.unlimited) == true
                expect(42 <= Demand.unlimited) == true
                expect(42 >= Demand.unlimited) == false
                expect(42 >  Demand.unlimited) == false

                expect(Demand.max(42) == .max(42)) == true
                expect(Demand.max(42) != .max(42)) == false
                expect(Demand.max(42) <  .max(42)) == false
                expect(Demand.max(42) <= .max(42)) == true
                expect(Demand.max(42) >= .max(42)) == true
                expect(Demand.max(42) >  .max(42)) == false
                expect(Demand.max(42) == 42) == true
                expect(Demand.max(42) != 42) == false
                expect(Demand.max(42) <  42) == false
                expect(Demand.max(42) <= 42) == true
                expect(Demand.max(42) >= 42) == true
                expect(Demand.max(42) >  42) == false
                expect(42 == Demand.max(42)) == true
                expect(42 != Demand.max(42)) == false
                expect(42 <  Demand.max(42)) == false
                expect(42 <= Demand.max(42)) == true
                expect(42 >= Demand.max(42)) == true
                expect(42 >  Demand.max(42)) == false

                expect(Demand.max(0) == .max(42)) == false
                expect(Demand.max(0) != .max(42)) == true
                expect(Demand.max(0) <  .max(42)) == true
                expect(Demand.max(0) <= .max(42)) == true
                expect(Demand.max(0) >= .max(42)) == false
                expect(Demand.max(0) >  .max(42)) == false
                expect(Demand.max(0) == 42) == false
                expect(Demand.max(0) != 42) == true
                expect(Demand.max(0) <  42) == true
                expect(Demand.max(0) <= 42) == true
                expect(Demand.max(0) >= 42) == false
                expect(Demand.max(0) >  42) == false
                expect(0 == Demand.max(42)) == false
                expect(0 != Demand.max(42)) == true
                expect(0 <  Demand.max(42)) == true
                expect(0 <= Demand.max(42)) == true
                expect(0 >= Demand.max(42)) == false
                expect(0 >  Demand.max(42)) == false

                expect(Demand.max(42) == .max(233)) == false
                expect(Demand.max(42) != .max(233)) == true
                expect(Demand.max(42) <  .max(233)) == true
                expect(Demand.max(42) <= .max(233)) == true
                expect(Demand.max(42) >= .max(233)) == false
                expect(Demand.max(42) >  .max(233)) == false
                expect(Demand.max(42) == 233) == false
                expect(Demand.max(42) != 233) == true
                expect(Demand.max(42) <  233) == true
                expect(Demand.max(42) <= 233) == true
                expect(Demand.max(42) >= 233) == false
                expect(Demand.max(42) >  233) == false
                expect(42 == Demand.max(233)) == false
                expect(42 != Demand.max(233)) == true
                expect(42 <  Demand.max(233)) == true
                expect(42 <= Demand.max(233)) == true
                expect(42 >= Demand.max(233)) == false
                expect(42 >  Demand.max(233)) == false
            }
        }
        
        // MARK: - Codable
        describe("Codable") {
            
            // MARK: 4.1 should be codable
            it("should be codable") {
                
                struct Q: Codable {
                    var a = Demand.unlimited
                    var b = Demand.max(10)
                }
                
                let q = Q()
                
                expect {
                    let encoder = JSONEncoder()
                    if #available(macOS 13.0, iOS 11.0, tvOS 11.0, watchOS 4.0, *) {
                        encoder.outputFormatting = [.sortedKeys]
                    } else {
                        // FIXME: output formatting
                    }
                    let data = try encoder.encode(q)
                    
                    expect(String(data: data, encoding: .utf8)) == #"{"a":9223372036854775808,"b":10}"#
                    
                    let decoder = JSONDecoder()
                    let x = try decoder.decode(Q.self, from: data)
                    
                    expect(x.a) == q.a
                    expect(x.b) == q.b
                    return ()
                }.toNot(throwError())
            }
        }
    }
}
