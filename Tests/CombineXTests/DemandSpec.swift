import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class DemandSpec: QuickSpec {
    
    typealias Demand = Subscribers.Demand
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Create
        describe("Create") {
            
            #if !SWIFT_PACKAGE
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
                expect(Demand.max(1) + Demand.max(.max)) == .unlimited
                expect(Demand.max(1) + Demand.unlimited) == .unlimited
                
                var d = Demand.max(1)
                d += .max(2)
                expect(d) == .max(3)
                
                expect(Demand.max(1) + (-1)) == .max(0)
                
                expect(Demand.unlimited + 1) == .unlimited
                expect(Demand.unlimited + .unlimited) == .unlimited
            }
            
            // MARK: 2.2 should sub as expected
            it("should sub as expected") {
                expect(Demand.max(2) - Demand.max(1)) == .max(1)
                expect(Demand.max(2) - 1) == .max(1)
                expect(Demand.unlimited - Demand.max(1)) == .unlimited
                expect(Demand.max(1) - Demand.unlimited) == .max(0)
                
                var d = Demand.max(2)
                d -= .max(1)
                expect(d) == .max(1)
                
                expect(Demand.max(1) - 1) == .max(0)
            }
            
            // MARK: 2.3 should multiply as expected
            it("should multiply as expected") {
                expect(Demand.max(1) * 7) == .max(7)
                expect(Demand.max(.max) * 2) == .unlimited
                
                expect(Demand.unlimited * 2) == .unlimited
                expect(Demand.unlimited * Int.max) == .unlimited
                
                #if !SWIFT_PACKAGE
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
                expect(Demand.max(1)) > .max(0)
                expect(Demand.max(1)) >= .max(1)
                
                expect(Demand.max(1) < 2) == true
                expect(Demand.max(1) <= 1) == true
                
                expect(Demand.unlimited) > .max(Int.max)
                expect(Demand.max(Int.max)) < .unlimited
                expect(Demand.unlimited) == .unlimited
                
                expect(Demand.unlimited).toNot(beLessThan(.unlimited))
                expect(Demand.unlimited).toNot(beGreaterThan(.unlimited))
                
                expect(Demand.max(1) > -1) == true
                expect(Demand.max(1) < -1) == false
            }
        }
        
        // MARK: - Codable
        describe("Codable") {
            
            // MARK: 4.1 should be codable
            it("should be codable") {
                
                struct Q: Codable {
                    let a = Demand.unlimited
                    let b = Demand.max(10)
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
